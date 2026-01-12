#!/usr/bin/env python3
"""
Purple Adblock Proxy Server
Proxy HTTP local pour bloquer les publicités Twitch
"""

import http.server
import socketserver
import urllib.request
import re
from urllib.parse import urlparse

PORT = 8888

class TwitchProxyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Récupérer l'URL réelle depuis l'en-tête
        target_url = self.path
        
        if target_url.startswith('http'):
            # C'est une vraie URL
            try:
                # Faire la requête vers Twitch
                req = urllib.request.Request(target_url)
                
                # Copier les headers
                for header, value in self.headers.items():
                    if header.lower() not in ['host', 'connection']:
                        req.add_header(header, value)
                
                response = urllib.request.urlopen(req)
                content = response.read()
                
                # Si c'est un fichier M3U8, filtrer les publicités
                if '.m3u8' in target_url:
                    content = self.filter_m3u8(content.decode('utf-8')).encode('utf-8')
                    print(f"[Purple Proxy] Filtered M3U8: {target_url}")
                
                # Envoyer la réponse
                self.send_response(200)
                self.send_header('Content-type', response.headers.get('Content-Type', 'text/plain'))
                self.send_header('Content-Length', len(content))
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(content)
                
            except Exception as e:
                print(f"[Purple Proxy] Error: {e}")
                self.send_error(502, f"Proxy Error: {str(e)}")
        else:
            self.send_error(400, "Bad Request")
    
    def filter_m3u8(self, content):
        """Filtre les segments publicitaires d'une playlist M3U8"""
        lines = content.split('\n')
        filtered = []
        skip_next = False
        
        for i, line in enumerate(lines):
            # Détecter les marqueurs de publicité
            if '#EXT-X-DATERANGE' in line and any(ad in line for ad in ['stitched-ad', 'AMAZON', 'commercial', 'AD-']):
                print(f"[Purple Proxy] Found ad marker: {line[:50]}...")
                skip_next = True
                continue
            
            # Sauter l'URL du segment après un marqueur de pub
            if skip_next and not line.startswith('#') and line.strip():
                print(f"[Purple Proxy] Skipped ad segment: {line[:50]}...")
                skip_next = False
                continue
            
            # Réinitialiser le flag si on trouve une autre directive
            if line.startswith('#') and skip_next:
                skip_next = False
            
            filtered.append(line)
        
        return '\n'.join(filtered)
    
    def log_message(self, format, *args):
        # Logs personnalisés
        if '.m3u8' in args[0] or 'playlist' in args[0]:
            print(f"[Purple Proxy] {format % args}")

def run_proxy():
    with socketserver.TCPServer(("127.0.0.1", PORT), TwitchProxyHandler) as httpd:
        print(f"[Purple Proxy] Starting proxy server on http://127.0.0.1:{PORT}")
        print("[Purple Proxy] Configure your app to use this proxy")
        print("[Purple Proxy] Press Ctrl+C to stop")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[Purple Proxy] Stopping proxy server...")

if __name__ == "__main__":
    run_proxy()
